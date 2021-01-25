import Moment from 'moment';
import React from 'react';
import _ from 'lodash';

import fetch from 'util/fetch';
import Image from './Image';

import {
  extractDeployedImage,
  fetchNomadStatus
} from 'components/NomadStatus/Data';

interface ImageListProps {
  endpoint: string;
  nomadStatusEndpoint: string;
  repositoryName: string;
  onSelect: (image: Image) => void;
  selectedImage?: Image;
  isMainOnlyDefault: boolean;
  isLatestOnlyDefault: boolean;
}

interface ImageListState {
  loading: boolean;
  error: boolean;
  images: Image[];
  displayedImages: Image[];
  currentImageTag: string;
  isMainOnly: boolean;
  isLatestOnly: boolean;
}

export default class ImageList extends React.Component<ImageListProps, ImageListState> {

  public state: ImageListState = {
    error: false,
    images: [],
    displayedImages: [],
    loading: true,
    currentImageTag: '',
    isMainOnly: this.props.isMainOnlyDefault,
    isLatestOnly: this.props.isLatestOnlyDefault
  };

  public componentDidMount() {
    this.handleFiltersChanged = this.handleFiltersChanged.bind(this);
    this.fetchData();
  }

  public render() {
    return (
      <div className='ImageList'>
        <h4>Available images</h4>
        { this.filters }
        { this.state.loading ? this.loadingMessage : this.content }
      </div>
    );
  }

  private get loadingMessage() {
    return <div className='ImageList-loadingMessage alert alert-secondary'>Loading images…</div>;
  }

  private get filters() {
    return (
      <div className='form-group'>
        <div className='form-check form-check-inline'>
          <input
            id='isMainOnly'
            name='isMainOnly'
            type='checkbox'
            className='form-check-input'
            checked={this.state.isMainOnly}
            onChange={this.handleFiltersChanged} />
          <label htmlFor='isMainOnly' className='form-check-label'>Show main/master only</label>
        </div>
        <div className='form-check form-check-inline'>
          <input
            id='isLatestOnly'
            name='isLatestOnly'
            type='checkbox'
            className='form-check-input'
            checked={this.state.isLatestOnly}
            onChange={this.handleFiltersChanged} />
          <label htmlFor='isLatestOnly' className='form-check-label'>Show latest only</label>
        </div>
      </div>
    );
  }

  private get content() {
    if (this.state.error) return this.errorMessage;

    return (
      <div className='list-group'>
        { this.state.displayedImages.length ? this.imageRows : this.emptyRow }
      </div>
    );
  }

  private get errorMessage() {
    return <div className='ImageList-errorMessage alert alert-danger'>Error fetching data.</div>;
  }

  private get emptyRow() {
    return (
      <div className='list-group-item list-group-item-warning'>
        No images were found for the repository <strong>{ this.props.repositoryName }</strong>.
      </div>
    );
  }

  private get imageRows() {
    return this.state.displayedImages.map((image) => {
      const isActive = !!(this.props.selectedImage && this.props.selectedImage.id === image.id);
      const className = `list-group-item flex-column align-items-start ${ isActive ? 'active' : 'not-active'}`;
      const isDeployed = _.includes(image.tags, this.state.currentImageTag);

      return (
        <div className={ className } key={ image.id } onClick={ () => this.props.onSelect(image) }>
          { isDeployed ? <div className="mb-2"><span className="badge badge-success">currently deployed</span></div> : null }
          <div className='d-flex w-100 justify-content-between align-items-start mb-2'>
            <span className='tags d-flex flex-wrap'>{ this.taggify(image.tags, isActive) }</span>
            <small>{ image.timestamp.locale('en-gb').calendar() }</small>
          </div>
          <small>{ image.fileSize }</small>
        </div>
      );
    });
  }

  handleFiltersChanged(event) {
    const value = event.target.checked;
    const name = event.target.name;
    this.setState(
      { [name]: value },
      () => this.setState( { displayedImages: this.filterImages(this.state.images) } )
    );
  }

  private taggify(tags: string[], isActive: boolean) {
    return tags.map((tag) =>
      <span key={ tag } className={ `badge ${isActive ? 'badge-light' : 'badge-primary'}` }>{ tag }</span>,
    );
  }

  private async fetchData() {
    try {
      const images = await this.fetchImageList();
      const displayedImages = this.filterImages(images);
      const currentImageTag = await this.fetchDeployedImageTag();

      this.setState({ loading: false, images, displayedImages, currentImageTag });
    } catch (_) {
      this.setState({ error: true, loading: false });
    }
  }

  private async fetchImageList() {
    const data = await fetch(this.props.endpoint);
    const json = await data.json();
    return json.map((d: { [s: string]: any }) => new Image(d));
  }

  private imageMainFilter(image) {
    return image.tags.some((tag) =>
      /^(master|main)/.test(tag)
    );
  }

  private imageLatestFilter(image) {
    return image.tags.some((tag) =>
      /latest$/.test(tag)
    );
  }

  private filterImages(images) {
    let filteredImages = images;
    if (this.state.isMainOnly) {
      filteredImages = filteredImages.filter(this.imageMainFilter);
    }
    if (this.state.isLatestOnly) {
      filteredImages = filteredImages.filter(this.imageLatestFilter);
    }
    return filteredImages;
  }

  private async fetchDeployedImageTag() {
    const nomadStatus = await fetchNomadStatus(this.props.nomadStatusEndpoint);
    const currentImage = extractDeployedImage(nomadStatus) || '';
    return _.last(currentImage.split(':')) || '';
  }
}
