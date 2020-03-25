import React from 'react';

import fetch from 'util/fetch';

import Image from './Image';

interface ImageDeployerProps {
  endpoint: string;
  selectedImage?: Image;
  deployButtonProps: {
    html_classes: string[],
    label: string
  };
}

interface ImageDeployerState {
  inProgress: boolean;
}

export default class ImageDeployer extends React.Component<ImageDeployerProps, ImageDeployerState> {
  public state = {
    inProgress: false,
  };

  public render() {
    return (
      <div className='ImageDeployer'>
        <h4>Deploy image</h4>
        { this.props.selectedImage ? this.deployImage : this.selectImageMessage }
        { this.state.inProgress ? this.overlay : null }
      </div>
    );
  }

  private get overlay() {
    return (
      <div className='ImageDeployer-overlay'>
        <div className='overlay'/>
        <div className='content'>
          <div>Deploying…</div>
        </div>
      </div>
    );
  }

  private get selectImageMessage() {
    return <div className='ImageDeployer-selectImageMessage alert alert-light'>Select an image to deploy</div>;
  }

  private get deployImage() {
    const { deployButtonProps: { html_classes, label } } = this.props;
    const htmlClasses = `btn btn-lg btn-block ${html_classes.join(' ')}`
    return (
      <div className='ImageDeployer-deployImage'>
        <a href='#' onClick={ this.onDeploy } className={htmlClasses}>{ label }</a>
      </div>
    );
  }

  private onDeploy = async (e: React.MouseEvent) => {
    e.preventDefault();

    this.setState({ inProgress: true });

    try {
      const data = await fetch(this.uri, { method: 'post' });
      const json = await data.json();

      this.setState({ inProgress: false });

      if (json.warnings) {
        alert('Something probably went wrong. Check Nomad.');
      }
    } catch (_) {
      alert('Something probably went wrong. Check Nomad.');
    }

    window.location.reload();
  }

  get uri() {
    if (!this.props.selectedImage) return '';

    return this.props.endpoint + '/' + this.deployTag;
  }

  get deployTag() {
    if (!this.props.selectedImage) return '';

    const buildTag = this.props.selectedImage.tags.find((t) => !!t.match(/^build/));

    return buildTag || this.props.selectedImage.tags[0];
  }
}
